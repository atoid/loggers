#include <mysql.h>
#include <my_global.h>
#include <cgic.h>
#include <string.h>

int sql_main(const char *query)
{
  int res = -1;
  MYSQL *con = mysql_init(NULL);

  if (con == NULL)
  {
      fprintf(cgiOut, "%s\n", mysql_error(con));
      return -1;
  }

  if (mysql_real_connect(con, "localhost", "root", "root",
          "talo", 0, NULL, 0) == NULL)
  {
    goto cleanup;
  }

  if (mysql_query(con, query))
  {
    goto cleanup;
  }

  MYSQL_RES *result = mysql_store_result(con);

  if (result == NULL)
  {
    goto cleanup;
  }

  int num_fields = mysql_num_fields(result);

  MYSQL_ROW row;

  while ((row = mysql_fetch_row(result)))
  {
      for (int i = 0; i < num_fields; i++)
      {
          fprintf(cgiOut, "%s ", row[i] ? row[i] : "NULL");
      }
      fprintf(cgiOut, "\n");
  }

  mysql_free_result(result);
  res = 0;
cleanup:
  if (res < 0)
  {
    fprintf(cgiOut, "%s\n", mysql_error(con));
  }
  mysql_close(con);
  return res;
}

int cgiMain()
{
  char query[128] = { 0 };
  cgiFormString("query", query, sizeof(query));
  cgiHeaderContentType("text/html");

  if (strlen(query) == 0 || sql_main(query) < 0)
  {
    fprintf(cgiOut, "QUERY FAIL");
  }

  return 0;
}
